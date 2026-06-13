# frozen_string_literal: true

module Virgil
  module TUI
    module Styles
      def self.header
        Lipgloss::Style.new
                       .foreground("#CD00CD")
                       .bold(true)
                       .margin_top(1)
                       .margin_bottom(1)
      end

      def self.card_border
        Lipgloss::Style.new
                       .border_style("rounded")
                       .border_foreground("#808080")
                       .padding(1)
      end

      def self.card_border_focused
        Lipgloss::Style.new
                       .border_style("rounded")
                       .border_foreground("#00D7FF")
                       .padding(1)
      end

      def self.card_title
        Lipgloss::Style.new
                       .foreground("#00D7FF")
                       .bold(true)
      end

      def self.card_expanded
        Lipgloss::Style.new
                       .foreground("#D0D0D0")
      end

      def self.card_collapsed
        Lipgloss::Style.new
                       .foreground("#808080")
      end

      def self.success
        Lipgloss::Style.new
                       .foreground("#00FF00")
      end

      def self.error
        Lipgloss::Style.new
                       .foreground("#FF0000")
      end

      def self.warning
        Lipgloss::Style.new
                       .foreground("#FFFF00")
      end

      def self.info
        Lipgloss::Style.new
                       .foreground("#00FFFF")
      end

      def self.progress
        Lipgloss::Style.new
                       .foreground("#FFD700")
      end

      def self.help_text
        Lipgloss::Style.new
                       .foreground("#505050")
                       .faint(true)
      end

      def self.input_style
        Lipgloss::Style.new
                       .foreground("#FFFFFF")
                       .background("#000000")
      end

      def self.cursor_style
        Lipgloss::Style.new
                       .background("#00FFFF")
      end
    end
  end
end
