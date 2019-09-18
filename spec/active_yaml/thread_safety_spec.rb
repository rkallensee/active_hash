require 'spec_helper'

describe ActiveYaml::Base, 'thread safety' do
  before do
    ActiveYaml::Base.set_root_path File.expand_path(File.dirname(__FILE__) + "/../fixtures")

    class City < ActiveYaml::Base; end
    #class City < ActiveHash::Base; end
    #City.data = [{:description => "A big region"}, {:description => "A remote region"}]
  end

  after do
    Object.send :remove_const, :City
  end

  describe 'when running multiple threads' do
    it 'have always loaded all cities' do
      thr = []
      f = ->(i) { thr << Thread.new { puts 'Thread ' + i.to_s + ': ' + City.all.length.to_s + " / #{City.dirty} / #{City.data_loaded}" } }

      for i in 0..10
        f.call(i)
      end

      puts thr.each(&:join)
    end
  end
end
