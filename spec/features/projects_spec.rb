require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  scenario 'user creates a new project' do
    user = FactoryBot.create(:user)

    sign_in(user)

    visit root_path

    expect {
      click_link 'New Project'
      fill_in 'Name', with: 'Test Project'
      fill_in 'Description', with: 'Trying out Capybara'
      click_button 'Create Project'

      expect(page).to have_content 'Project was successfully created'
      expect(page).to have_content 'Test Project'
      expect(page).to have_content "Owner: #{user.name}"
    }.to change(user.projects, :count).by(1)

    expect {
      visit projects_path
      click_link 'New Project'
      click_link 'Cancel'

      expect(current_path).to eq(projects_path)
    }.to_not change(user.projects, :count)
  end

  scenario 'user updates the project' do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, :due_today, owner: user)

    sign_in(user)

    visit root_path
    click_link project.name
    click_link 'Edit'
    fill_in 'Name', with: project.name.reverse
    fill_in 'Description', with: project.description.reverse
    select 1.year.from_now.year, from: 'project_due_on_1i'
    select 1.month.from_now.strftime("%B"), from: 'project_due_on_2i'
    select 1.day.from_now.day, from: 'project_due_on_3i'
    click_button 'Update Project'

    expect(page).to have_content project.name.reverse
    expect(page).to have_content project.description.reverse
    expect(page).to_not have_content project.name
    expect(page).to_not have_content project.description
    expect(page).to have_content(
      1.month.from_now.strftime("%B") + ' ' +
        1.day.from_now.strftime('%d').to_s + ', ' +
          1.year.from_now.year.to_s
    )

    click_link 'Edit'
    click_link 'Cancel'

    expect(current_path).to eq(project_path(project))
  end
end
