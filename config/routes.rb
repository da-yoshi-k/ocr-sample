Rails.application.routes.draw do
  resources :documents do
    get 'texts', to: 'documents#execute_ocr'
    get 'vision_texts', to: 'documents#execute_vision_api'
  end
  root to: 'documents#index'
end
