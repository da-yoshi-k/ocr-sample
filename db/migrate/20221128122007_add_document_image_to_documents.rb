class AddDocumentImageToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :document_image, :string
  end
end
