# frozen_string_literal: true

module Virgil
  module TUI
    module Screens
      # Prompt input screen with centered TextArea
      class Prompt
        include Bubbletea::Model

        # TODO: remove `textarea`, `width`, and `height`? Are these accessed
        # outside of the instance at all?
        attr_reader :textarea, :width, :height

        def initialize(width: 80, height: 24)
          @width = width
          @height = height
          @textarea = Bubbles::TextArea.new(width: width, height: 10)
          @textarea.focus
        end

        def update(message)
          case message
          when Bubbletea::KeyMessage
            return handle_key(message)
          when ResizeMessage
            @width = message.width
            @height = message.height
          else
            @textarea.update(message)
          end
          [self, nil]
        end

        def view
          title = Styles.header.render("What are we researching today?")
          textarea_view = @textarea.view

          padding_top = (@height / 3).to_i
          padding_bottom = @height - padding_top - 10

          Lipgloss.place(
            @width,
            padding_top + 10 + padding_bottom,
            Lipgloss::Position::CENTER,
            Lipgloss::Position::CENTER,
            "#{title}\n#{textarea_view}"
          )
        end

        private

        def handle_key(message)
          case message.name
          when "ctrl+c"
            return [self, Bubbletea.quit]
          when "enter"
            prompt = @textarea.value.strip
            return [self, Bubbletea.send_message(SubmitPromptMessage.new(prompt: prompt))] unless prompt.empty?
          else
            @textarea.update(message)
          end
          [self, nil]
        end
      end
    end
  end
end
