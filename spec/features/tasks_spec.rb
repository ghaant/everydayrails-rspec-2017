require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
  scenario 'user creates a new task' do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, name: 'RSpec tutorial', owner: user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link project.name

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
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, name: 'RSpec tutorial', owner: user)
    task = project.tasks.create!(name: 'Finish RSpec tutorial')

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link project.name
    within_table('') { click_link 'Edit' }
    fill_in 'Name', with: task.name.reverse
    click_button 'Update Task'

    expect(page).to have_content task.name.reverse
    expect(page).to_not have_content task.name

    within_table('') { click_link 'Edit' }
    click_link 'Cancel'

    expect(current_path).to eq(project_path(project))
  end

  scenario 'user toggles a task', js: true do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, name: 'RSpec tutorial', owner: user)
    task = project.tasks.create!(name: 'Finish RSpec tutorial')

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link 'RSpec tutorial'
    check 'Finish RSpec tutorial'

    expect(page).to have_css "label#task_#{task.id}.completed"
    expect(task.reload).to be_completed

    uncheck 'Finish RSpec tutorial'
    expect(page).to_not have_css "label#task_#{task.id}.completed"
    expect(task.reload).to_not be_completed
  end
end
