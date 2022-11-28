class Document < ApplicationRecord
  mount_uploader :document_image, DocumentImageUploader
end
