# frozen_string_literal: true

require 'spec_helper'

describe Rubyipmi::SensorsMixin do
  let(:reader) do
    Class.new do
      include Rubyipmi::SensorsMixin

      def initialize
        @reads = 0
      end

      attr_reader :reads

      def getsensors
        @reads += 1
        value = @reads == 1 ? '40' : '50'
        "cpu temp | #{value} | degrees C\n"
      end

      def sensor_class
        Class.new do
          def initialize(line)
            name, value, unit = line.split('|').map(&:strip)
            @attrs = {:name => name, :value => value, :unit => unit}
          end

          def [](key)
            @attrs[key]
          end
        end
      end
    end.new
  end

  it 'reuses the cached list until refresh' do
    expect(reader.list['cpu temp'][:value]).to eq('40')
    expect(reader.list['cpu temp'][:value]).to eq('40')
    expect(reader.reads).to eq(1)

    expect(reader.refresh['cpu temp'][:value]).to eq('50')
    expect(reader.reads).to eq(2)
    expect(reader.list['cpu temp'][:value]).to eq('50')
  end
end
