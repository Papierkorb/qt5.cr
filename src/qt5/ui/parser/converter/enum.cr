module Qt::Ui
  class Parser
    module Converter
      #########################################
      # Convert strings into values
      #########################################

      def string_to_size_policy(string : String) : Qt::SizePolicy::Policy
        case string
        when "QSizePolicy::Fixed"
          Qt::SizePolicy::Policy::Fixed
        when "QSizePolicy::Minimum"
          Qt::SizePolicy::Policy::Minimum
        when "QSizePolicy::Maximum"
          Qt::SizePolicy::Policy::Maximum
        when "QSizePolicy::Preferred"
          Qt::SizePolicy::Policy::Preferred
        when "QSizePolicy::MinimumExpanding"
          Qt::SizePolicy::Policy::MinimumExpanding
        when "QSizePolicy::Expanding"
          Qt::SizePolicy::Policy::Expanding
        when "QSizePolicy::Ignored"
          Qt::SizePolicy::Policy::Ignored
        else
          raise "unable to convert \"#{string}\" to Qt::SizePolicy::Policy"
        end
      end

      def string_to_scroll_area(string : String) : Qt::AbstractScrollArea::SizeAdjust
        case string
        when "QAbstractScrollArea::AdjustIgnored"
          Qt::AbstractScrollArea::SizeAdjust::AdjustIgnored
        when "QAbstractScrollArea::AdjustToContentsOnFirstShow"
          Qt::AbstractScrollArea::SizeAdjust::AdjustToContentsOnFirstShow
        when "QAbstractScrollArea::AdjustToContents"
          Qt::AbstractScrollArea::SizeAdjust::AdjustToContents
        else
          raise "unable to convert \"#{string}\" to Qt::AbstractScrollArea::SizeAdjust"
        end
      end

      def string_to_scroll_bar_policy(string : String) : Qt::ScrollBarPolicy
        case string
        when "Qt::ScrollBarAsNeeded"
          Qt::ScrollBarPolicy::AsNeeded
        when "Qt::ScrollBarAlwaysOff"
          Qt::ScrollBarPolicy::AlwaysOff
        when "Qt::ScrollBarAlwaysOn"
          Qt::ScrollBarPolicy::AlwaysOn
        else
          raise "unable to convert \"#{string}\" to Qt::ScrollBarPolicy"
        end
      end

      def string_to_tab_enum(string : String) : Qt::TabWidget::TabPosition | Qt::TabWidget::TabShape
        case string
        when "QTabWidget::North"
          Qt::TabWidget::TabPosition::North
        when "QTabWidget::South"
          Qt::TabWidget::TabPosition::South
        when "QTabWidget::West"
          Qt::TabWidget::TabPosition::West
        when "QTabWidget::East"
          Qt::TabWidget::TabPosition::East
        when "QTabWidget::Triangular"
          Qt::TabWidget::TabShape::Triangular
        when "QTabWidget::Rounded"
          Qt::TabWidget::TabShape::Rounded
        else
          raise "unable to convert \"#{string}\" to Qt::TabWidget::TabPosition or Qt::TabWidget::TabShape"
        end
      end

      def string_to_elide_mode(string : String) : Qt::TextElideMode
        case string
        when "Qt::ElideLeft"
          Qt::TextElideMode::Left
        when "Qt::ElideRight"
          Qt::TextElideMode::Right
        when "Qt::ElideMiddle"
          Qt::TextElideMode::Middle
        when "Qt::ElideNone"
          Qt::TextElideMode::None
        else
          raise "unable to convert \"#{string}\" to Qt::TextElideMode"
        end
      end

      # Will convert the provided string into a `Qt::Alignment` flag
      def string_to_alignment(string : String) : Qt::Alignment
        items = string.split('|').map do |s|
          string_to_alignment_single(s)
        end
        Qt::Alignment.new(items.map(&.value).sum)
      end

      # Will convert the provided string into a single `Qt::Alignment`
      def string_to_alignment_single(string : String) : Qt::Alignment
        case string
        when "Qt::AlignLeft"
          Qt::Alignment::AlignLeft
        when "Qt::AlignLeading"
          Qt::Alignment::AlignLeading
        when "Qt::AlignRight"
          Qt::Alignment::AlignRight
        when "Qt::AlignTrailing"
          Qt::Alignment::AlignTrailing
        when "Qt::AlignHCenter"
          Qt::Alignment::AlignHCenter
        when "Qt::AlignJustify"
          Qt::Alignment::AlignJustify
        when "Qt::AlignAbsolute"
          Qt::Alignment::AlignAbsolute
        when "Qt::AlignHorizontal_Mask"
          Qt::Alignment::AlignHorizontal_Mask
        when "Qt::AlignTop"
          Qt::Alignment::AlignTop
        when "Qt::AlignBottom"
          Qt::Alignment::AlignBottom
        when "Qt::AlignVCenter"
          Qt::Alignment::AlignVCenter
        when "Qt::AlignBaseline"
          Qt::Alignment::AlignBaseline
        when "Qt::AlignVertical_Mask"
          Qt::Alignment::AlignVertical_Mask
        when "Qt::AlignCenter"
          Qt::Alignment::AlignCenter
        else
          raise "unable to convert \"#{string}\" to Qt::Frame::Shape"
        end
      end

      # Will convert the provided string into a `Qt::Frame::Shape` or `Qt::Frame::Shadow`
      def string_to_frame_enum(string) : Qt::Frame::Shape | Qt::Frame::Shadow
        begin
          string_to_frame_shape(string)
        rescue
          string_to_frame_shadow(string)
        end
      rescue ex
        raise "unable to convert \"#{string}\" to Qt::Frame::Shape or Qt::Frame::Shadow"
      end

      # Will convert the provided string into a `Qt::Frame::Shape`
      def string_to_frame_shape(string) : Qt::Frame::Shape
        case string
        when "QFrame::NoFrame"
          Qt::Frame::Shape::NoFrame
        when "QFrame::Box"
          Qt::Frame::Shape::Box
        when "QFrame::Panel"
          Qt::Frame::Shape::Panel
        when "QFrame::WinPanel"
          Qt::Frame::Shape::WinPanel
        when "QFrame::Hline"
          Qt::Frame::Shape::Hline
        when "QFrame::Vline"
          Qt::Frame::Shape::Vline
        when "QFrame::StyledPanel"
          Qt::Frame::Shape::StyledPanel
        else
          raise "unable to convert \"#{string}\" to Qt::Frame::Shape"
        end
      end

      def string_to_color_role(string) : Qt::Palette::ColorRole
        {% begin %}
        case string
        {% for c in Qt::Palette::ColorRole.constants %}
        when {{c.id.stringify}}
          Qt::Palette::ColorRole::{{c.id}}
        {% end %}
        else
          raise "unable to convert \"#{string}\" to Qt::Palette::ColorRole"
        end
        {% end %}
      end

      def string_to_color_group(string) : Qt::Palette::ColorGroup
        {% begin %}
        case string
        {% for c in Qt::Palette::ColorGroup.constants %}
        when {{c.id.stringify}}, {{c.id.downcase.stringify}}
          Qt::Palette::ColorGroup::{{c.id}}
        {% end %}
        else
          raise "unable to convert \"#{string}\" to Qt::Palette::ColorGroup"
        end
        {% end %}
      end

      def string_to_brush_style(string : String) : Qt::BrushStyle
        {% begin %}
        case string
        {% for c in Qt::BrushStyle.constants %}
        when {{c.id.stringify}}
          Qt::BrushStyle::{{c.id}}
        {% end %}
        else
          raise "unable to convert \"#{string}\" to Qt::BrushStyle"
        end
        {% end %}
      end

      # Will convert the provided string into a `Qt::Frame::Shadow`
      def string_to_frame_shadow(string) : Qt::Frame::Shadow
        case string
        when "QFrame::Plain"
          Qt::Frame::Shadow::Plain
        when "QFrame::Raised"
          Qt::Frame::Shadow::Raised
        when "QFrame::Sunken"
          Qt::Frame::Shadow::Sunken
        else
          raise "unable to convert \"#{string}\" to Qt::Frame::Shadow"
        end
      end
    end
  end
end
