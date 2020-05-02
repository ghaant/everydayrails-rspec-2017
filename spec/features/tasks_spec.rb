require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
  let(:user) { FactoryBot.create(:user )}
  let(:project) { FactoryBot.create(:project, name: 'RSpec tutorial', owner: user) }
  let!(:task) { project.tasks.create!(name: 'Finish RSpec tutorial') }

  scenario 'user creates a new task' do
    sign_in(user)
    visit project_path(project.id)

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

  scenario 'user updates the task' do
    sign_in(user)
    visit project_path(project.id)
    within_table('') { click_link 'Edit' }
    fill_in 'Name', with: task.name.reverse
    click_button 'Update Task'

    expect(page).to have_content task.name.reverse
    expect(page).to_not have_content task.name

    within_table('') { click_link 'Edit' }
    click_link 'Cancel'

    expect(current_path).to eq(project_path(project))
  end

  # scenario 'user toggles a task', js: true do
  #   task = project.tasks.create!(name: 'Finish RSpec tutorial')
  #
  #   visit root_path
  #   click_link 'Sign in'
  #   fill_in 'Email', with: user.email
  #   fill_in 'Password', with: user.password
  #   click_button 'Log in'
  #
  #   click_link 'RSpec tutorial'
  #   check 'Finish RSpec tutorial'
  #
  #   expect(page).to have_css "label#task_#{task.id}.completed"
  #   expect(task.reload).to be_completed
  #
  #   uncheck 'Finish RSpec tutorial'
  #   expect(page).to_not have_css "label#task_#{task.id}.completed"
  #   expect(task.reload).to_not be_completed
  # end

  scenario 'user deletes the task' do
    sign_in(user)
    visit project_path(project.id)

    expect {
      within_table('') { click_link 'Delete' }

      expect(current_path).to eq(project_path(project))
      expect(page).to_not have_content task.name
    }.to change(project.tasks, :count).by(-1)
  end
end
