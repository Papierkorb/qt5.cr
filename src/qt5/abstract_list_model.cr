abstract class Qt::AbstractListModel
  def row_count : Int32
    Binding.bg_QAbstractItemModel_rowCount_(self)
  end

  def column_count : Int32
    Binding.bg_QAbstractItemModel_columnCount_(self)
  end
end

def Qt::ItemDataRole.new(val : Int32)
  Qt::ItemDataRole.new(val.to_u)
end
