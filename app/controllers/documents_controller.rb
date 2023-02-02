class DocumentsController < ApplicationController
  before_action :set_document, only: %i[ show edit update destroy ]

  # GET /documents or /documents.json
  def index
    @documents = Document.all
  end

  # GET /documents/1 or /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents or /documents.json
  def create
    @document = Document.new(document_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to document_url(@document), notice: "Document was successfully created." }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1 or /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to document_url(@document), notice: "Document was successfully updated." }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1 or /documents/1.json
  def destroy
    @document.destroy

    respond_to do |format|
      format.html { redirect_to documents_url, notice: "Document was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def execute_ocr
    @document = Document.find(params[:document_id])
    # ローカルに保存している場合はこっち
    # image_url = "#{Rails.root}/public#{@document.document_image.url}"
    # S3の場合はそのままのURL
    image_url = @document.document_image.url
    image = RTesseract.new(image_url, lang: params[:language])
    @text = image.to_s.gsub(/(\r\n|\r|\n)/, '\\n')
    @text = 'テキストが検出できませんでした' if @text.blank?
  end

  def execute_vision_api
    @document = Document.find(params[:document_id])
    image = @document.document_image.url(query: { 'response-content-disposition' => 'attachment' })
    image_annotator_client = Google::Cloud::Vision::V1::ImageAnnotator::Client.new
    response = image_annotator_client.document_text_detection(
      image: image, max_results: 1, image_context: { language_hints: %i[ja en] }
    )
    @vision_text = ''
    response.responses.each do |res|
      @vision_text << res.text_annotations[0].description.gsub(/(\r\n|\r|\n)/, '\\n')
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_document
    @document = Document.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def document_params
    params.require(:document).permit(:title, :description, :document_image)
  end
end
