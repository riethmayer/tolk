require 'test_helper'

class LocaleTest < ActiveSupport::TestCase
  fixtures :all

  test "turning locale without nested phrases into a hash" do
    assert_equal({ "se" => { "hello_world" => "Hejsan Verdon" } }, tolk_locales(:se).to_hash)
  end

  test "turning locale with nested phrases into a hash" do
    assert_equal({ "en" => {
      "number"=>{"human"=>{"format"=>{"precision"=>1}}},
      "hello_world" => "Hello World",
      "nested" => {
        "hello_world" => "Nested Hello World",
        "hello_country" => "Nested Hello Country"
      }
    }}, tolk_locales(:en).to_hash)
  end

  test "phrases without translations" do
    assert tolk_locales(:en).phrases_without_translation.include?(tolk_phrases(:cozy))
  end

  test "searching phrases without translations" do
    # assert tolk_locales(:en).search_phrases_without_translation("cozy").include?(tolk_phrases(:cozy))
    assert !tolk_locales(:en).search_phrases_without_translation("cozy").include?(tolk_phrases(:hello_world))
  end

  test "counting missing translations" do
    assert_equal 2, tolk_locales(:da).count_phrases_without_translation
    assert_equal 4, tolk_locales(:se).count_phrases_without_translation
  end

  test "dumping all locales to yml" do
    Tolk::Locale.primary_locale_name = 'en'
    Tolk::Locale.primary_locale(true)

    begin
      FileUtils.mkdir_p(Rails.root.join("../../tmp/locales"))
      Tolk::Locale.dump_all(Rails.root.join("../../tmp/locales"))

      %w( da se ).each do |locale|
        assert_equal \
          File.read(Rails.root.join("../locales/basic/#{locale}.yml")),
          File.read(Rails.root.join("../../tmp/locales/#{locale}.yml"))
      end

      # Make sure dump doesn't generate en.yml
      assert ! File.exists?(Rails.root.join("../../tmp/locales/en.yml"))
    ensure
      FileUtils.rm_rf(Rails.root.join("../../tmp/locales"))
    end
  end

  test "human language name" do
    assert_equal 'English', tolk_locales(:en).language_name
    assert_equal 'pirate', Tolk::Locale.new(:name => 'pirate').language_name
  end
end
