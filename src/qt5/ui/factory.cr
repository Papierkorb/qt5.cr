module Qt::Ui
  class Factory
    private getter document : XML::Node
    private getter root_name : String

    def initialize(ui_file_path)
      doc = XML.parse(File.read(ui_file_path))

      ui = doc.first_element_child
      raise "unable to parse document" if ui.nil?
      # Grab the class element
      r = ui.children.select(&.element?).find(&.name.==("class"))
      raise "unable to parse root document" if r.nil?
      @root_name = r.content
      @document = ui
    end

    def create! : Qt::Ui::Data
      Qt::Ui::Parser.new(self.document, self.root_name).parse!.data
    end
  end
end
