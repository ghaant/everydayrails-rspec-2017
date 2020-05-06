require 'rails_helper'

RSpec.feature "Tasks", type: :system do
  let(:user) { FactoryBot.create(:user )}
  let(:project) { FactoryBot.create(:project, name: 'RSpec tutorial', owner: user) }
  let!(:task) { project.tasks.create!(name: 'Finish RSpec tutorial') }

  it 'creates a new task as a user' do
    sign_in(user)
    go_to_project 'RSpec tutorial'

    expect {
      click_link 'Add Task'
      fill_in 'Name', with: 'The first task'
      click_button 'Create Task'
      expect(page).to have_content('The first task')
    }.to change(project.tasks, :count).by(1)

    expect {
      click_link 'Add Task'
      click_link 'Cancel'

      expect(current_path).to eq(project_path(project))
    }.to_not change(project.tasks, :count)
  end

  it 'updates the task as a user' do
    sign_in(user)
    go_to_project 'RSpec tutorial'
    within_table('') { click_link 'Edit' }
    fill_in 'Name', with: task.name.reverse
    click_button 'Update Task'

    expect(page).to have_content task.name.reverse
    expect(page).to_not have_content task.name

    within_table('') { click_link 'Edit' }
    click_link 'Cancel'

    expect(current_path).to eq(project_path(project))
  end

  it 'toggles a task as a user', js: true do
    skip 'some problem on Ubuntu'
    sign_in(user)
    go_to_project 'RSpec tutorial'
    complete_task 'Finish RSpec tutorial'
    expect_complete_task 'Finish RSpec tutorial'
    undo_complete_task 'Finish RSpec tutorial'
    expect_incomplete_task 'Finish RSpec tutorial'
  end

  it 'deletes the task as a user' do
    sign_in(user)
    go_to_project 'RSpec tutorial'

    expect {
      within_table('') { click_link 'Delete' }

      expect(current_path).to eq(project_path(project))
      expect(page).to_not have_content task.name
    }.to change(project.tasks, :count).by(-1)
  end

  def go_to_project(name)
    visit root_path
    click_link name
  end

  def complete_task(name)
    check name
  end

  def undo_complete_task(name)
    uncheck name
  end

  def expect_complete_task(name)
    aggregate_failures do
      expect(page).to have_css "label.completed", text: name
      expect(task.reload).to be_completed
    end
  end

  def expect_incomplete_task(name)
    aggregate_failures do
      expect(page).to_not have_css "label.completed", text: name
      expect(task.reload).to_not be_completed
    end
  end
end
