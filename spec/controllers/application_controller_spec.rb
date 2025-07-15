require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index; render plain: 'OK'; end
  end

  describe '#current_program' do
    context 'when an error is rescued' do
      it 'sets a flash alert' do
        allow(ProgramSetting).to receive(:active_program).and_raise(StandardError)
        controller.send(:current_program)
        expect(flash.now[:alert]).to eq('There are no active programs!')
      end
    end
  end

  describe '#current_program_open?' do
    let(:program_setting) { double('ProgramSetting') }

    context 'when a current program exists' do
      before do
        allow(controller).to receive(:current_program).and_return(program_setting)
      end

      context 'and the program is open' do
        it 'returns true' do
          allow(program_setting).to receive(:program_open).and_return(1.hour.ago)
          allow(program_setting).to receive(:program_close).and_return(1.hour.from_now)
          expect(controller.current_program_open?).to be true
        end
      end

      context 'and the program is not open yet' do
        it 'returns false' do
          allow(program_setting).to receive(:program_open).and_return(1.hour.from_now)
          allow(program_setting).to receive(:program_close).and_return(2.hours.from_now)
          expect(controller.current_program_open?).to be false
        end
      end

      context 'and the program has already closed' do
        it 'returns false' do
          allow(program_setting).to receive(:program_open).and_return(2.hours.ago)
          allow(program_setting).to receive(:program_close).and_return(1.hour.ago)
          expect(controller.current_program_open?).to be false
        end
      end
    end

    context 'when no current program exists' do
      it 'returns nil' do
        allow(controller).to receive(:current_program).and_return(nil)
        expect(controller.current_program_open?).to be_nil
      end
    end
  end
end
