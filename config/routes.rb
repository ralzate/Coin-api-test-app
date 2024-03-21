Rails.application.routes.draw do
  root 'welcome#index'
  post 'welcome/export'
end
