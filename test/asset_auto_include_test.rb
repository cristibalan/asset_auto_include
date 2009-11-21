RAILS_ROOT = File.dirname(__FILE__) + '/fixtures'
require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'action_controller'
require 'asset_auto_include'

class AssetAutoIncludeTest < ActiveSupport::TestCase
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper

  def test_javascript_return_with_no_matching_controller_or_action_and_no_manual
    @controller = Class.new do
      def controller_path
        'not_included'
      end
      def action_name
        'not_here'
      end
    end.new
    expected = "<!-- auto javascript -->\n\n<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_javascript_return_with_default_auto_include_no_action_and_no_manual
    @controller = Class.new do
      def controller_path
        'auto_include'
      end
      def action_name
        'not_here'
      end
    end.new
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/auto/auto_include.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_javascript_return_with_auto_include_namespace_action_and_no_manual
    @controller = Class.new do
      def controller_path
        'auto_include/namespace'
      end
      def action_name
        'index'
      end
    end.new
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/auto/auto_include.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/namespace/index.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_javascript_return_with_views_auto_include_with_action_and_no_manual
    @controller = Class.new do
      def controller_path
        'auto_include'
      end
      def action_name
        'test'
      end
    end.new
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/auto/auto_include.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/test-also.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/test.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/include-also-test.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/include-test-also.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/include-test.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_stylesheet_return_with_auto_include_namespace_action_and_no_manual
    @controller = Class.new do
      def controller_path
        'auto_include/namespace'
      end
      def action_name
        'index'
      end
    end.new
    expected = "<!-- auto stylesheet -->\n"
    expected += "<link href=\"/stylesheets/auto/auto_include/namespace.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n"
    expected += "<link href=\"/stylesheets/auto/auto_include/namespace/index.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n"
    expected += "<!-- /auto stylesheet -->"
    results = asset_auto_include_tags :stylesheet
    assert_equal(expected, results)
  end
  def test_javascript_return_with_manual_and_no_controller_or_action
    @controller = Class.new do
      def controller_path
        'not_included'
      end
      def action_name
        'not_here'
      end
    end.new   
    register_asset_auto_include 'manual',  :javascript
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/manual.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_javascript_return_with_manual_from_controller_and_no_controller_or_action
    @controller = Class.new do
      def controller_path
        'not_included'
      end
      def action_name
        'not_here'
      end
    end.new   
    ActionView::Helpers::AssetTagHelper::register_asset_auto_include 'manual',  :javascript
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/manual.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_stylesheet_return_with_manual_and_no_controller_or_action
    @controller = Class.new do
      def controller_path
        'not_included'
      end
      def action_name
        'not_here'
      end
    end.new   
    expected = "<!-- auto stylesheet -->\n"
    expected += "<link href=\"/stylesheets/manual.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n"
    expected += "<!-- /auto stylesheet -->"
    register_asset_auto_include 'manual',  :stylesheet
    results = asset_auto_include_tags :stylesheet
    assert_equal(expected, results)
  end
  def test_both_return_with_manual_and_no_controller_or_action
    @controller = Class.new do
      def controller_path
        'not_included'
      end
      def action_name
        'not_here'
      end
    end.new   
    register_asset_auto_include 'manual'
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/manual.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    expected += "<!-- auto stylesheet -->\n"
    expected += "<link href=\"/stylesheets/manual.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n"
    expected += "<!-- /auto stylesheet -->"
    results = asset_auto_include_tags :javascript
    results += asset_auto_include_tags :stylesheet
    assert_equal(expected, results)
  end
  def test_javascript_return_with_views_auto_include_and_manual
    @controller = Class.new do
      def controller_path
        'auto_include'
      end
      def action_name
        'not_here'
      end
    end.new   
    register_asset_auto_include 'manual',  :javascript
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/auto/auto_include.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/manual.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_javascript_return_with_views_auto_include_with_action_and_manual
    @controller = Class.new do
      def controller_path
        'auto_include'
      end
      def action_name
        'test'
      end
    end.new
    register_asset_auto_include 'manual',  :javascript
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/auto/auto_include.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/test-also.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/test.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/include-also-test.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/include-test-also.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/auto/auto_include/include-test.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/manual.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
  def test_return_with_action_only_and_manual
    @controller = Class.new do
      def controller_path
        'no_controller_script'
      end
      def action_name
        'test'
      end
    end.new   
    register_asset_auto_include 'manual',  :javascript
    expected = "<!-- auto javascript -->\n"
    expected += "<script src=\"/javascripts/auto/no_controller_script/test.js\" type=\"text/javascript\"></script>\n"
    expected += "<script src=\"/javascripts/manual.js\" type=\"text/javascript\"></script>\n"
    expected += "<!-- /auto javascript -->"
    results = asset_auto_include_tags :javascript
    assert_equal(expected, results)
  end
end
