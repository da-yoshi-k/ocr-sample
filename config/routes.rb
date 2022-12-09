Rails.application.routes.draw do
  resources :documents do
    get 'texts', to: 'documents#execute_ocr'
  end
  root to: 'documents#index'
end
