require "spec_helper"
module Alf
  module Sequel
    module UnitOfWork
      describe Atomic, "run" do

        def build_uow(&bl)
          Object.new.tap{|uow|
            uow.extend(Atomic)
            uow.singleton_class.send(:define_method, :_run, &bl)
          }
        end

        subject{ uow.run }

        context 'when the block succeeds' do
          let(:uow){ build_uow{ true } }

          it 'returns itself' do
            subject.should be(uow)
          end

          it 'sets ran? to true' do
            subject.should be_ran
          end

          it 'sets failed? to false' do
            subject.should_not be_failed
          end
        end

        context 'when the block fails' do
          let(:uow){ build_uow{ raise ArgumentError, "failed" } }

          it 'raise the error' do
            lambda{
              subject
            }.should raise_error(ArgumentError, "failed")
          end

          it 'sets ran? to true' do
            lambda{ subject }.should raise_error
            uow.should be_ran
          end

          it 'sets failed? to false' do
            lambda{ subject }.should raise_error
            uow.should be_failed
          end

          it 'sets failure to the error' do
            lambda{ subject }.should raise_error
            uow.failure.should be_a(ArgumentError)
          end
        end

        context 'when already ran' do
          let(:uow){ build_uow{ true } }

          before{ uow.run }

          it 'raises an Alf::IllegalStateError' do
            lambda{
              subject
            }.should raise_error(IllegalStateError, /already ran/)
          end
        end

      end
    end # module UnitOfWork
  end # module Sequel
end # module Alf
