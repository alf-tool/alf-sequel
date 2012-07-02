require 'spec_helper'
module Alf
  module Sequel
    describe Adapter, "auto_transaction?" do

      before do
        class Adapter; public :auto_transaction?; end
      end

      subject{ sequel_adapter.auto_transaction?(options) }

      context 'on empty options' do
        let(:options){ {} }
        it{ should be_true }
      end

      context 'on explicit :transaction => true' do
        let(:options){ {:transaction => true} }
        it{ should be_true }
      end

      context 'on explicit :transaction => false' do
        let(:options){ {:transaction => false} }
        it{ should be_false }
      end

      context 'on explicit :transaction => nil' do
        let(:options){ {:transaction => nil} }
        it{ should be_false }
      end

    end
  end
end