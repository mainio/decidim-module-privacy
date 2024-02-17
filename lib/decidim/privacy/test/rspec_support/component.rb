# frozen_string_literal: true

module ComponentTestHelper
  def visit_component
    page.visit main_component_path(component)
  end
end
