# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::GithubPageValidator do
  let(:browser) { double('Browser') }
  subject(:validator) { described_class.new(browser) }

  describe '#validate!' do
    context 'when page is a valid profile' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(200)
        allow(browser).to receive(:at_css).with('title').and_return(double(text: 'torvalds - GitHub'))
        allow(browser).to receive(:body).and_return('<html><span class="vcard-username">torvalds</span></html>')
      end

      it 'does not raise any error' do
        expect { validator.validate! }.not_to raise_error
      end
    end

    context 'when HTTP status is 404' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(404)
      end

      it 'raises ProfileNotFoundError' do
        expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, "Perfil não encontrado (404)")
      end
    end

    context 'when HTTP status is 500' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(500)
      end

      it 'raises StandardError' do
        expect { validator.validate! }.to raise_error(StandardError, "Erro HTTP 500 ao acessar perfil")
      end
    end

    context 'when browser does not support status method' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(false)
        allow(browser).to receive(:at_css).with('title').and_return(double(text: 'torvalds - GitHub'))
        allow(browser).to receive(:body).and_return('<html><span class="vcard-username">torvalds</span></html>')
      end

      it 'skips status check and continues validation' do
        expect { validator.validate! }.not_to raise_error
      end
    end

    context 'when browser.status raises NoMethodError' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_raise(NoMethodError)
        allow(browser).to receive(:at_css).with('title').and_return(double(text: 'torvalds - GitHub'))
        allow(browser).to receive(:body).and_return('<html><span class="vcard-username">torvalds</span></html>')
      end

      it 'rescues and continues validation' do
        expect { validator.validate! }.not_to raise_error
      end
    end

    context 'when page title contains "404"' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(200)
        allow(browser).to receive(:at_css).with('title').and_return(double(text: '404 Not Found - GitHub'))
        allow(browser).to receive(:body).and_return('<html></html>')
      end

      it 'raises ProfileNotFoundError' do
        expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, "Perfil não encontrado")
      end
    end

    context 'when page title contains "not found"' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(200)
        allow(browser).to receive(:at_css).with('title').and_return(double(text: 'Page Not Found - GitHub'))
        allow(browser).to receive(:body).and_return('<html></html>')
      end

      it 'raises ProfileNotFoundError' do
        expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, "Perfil não encontrado")
      end
    end

    context 'when page title is nil' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(200)
        allow(browser).to receive(:at_css).with('title').and_return(nil)
        allow(browser).to receive(:body).and_return('<html><span class="vcard-username">torvalds</span></html>')
      end

      it 'does not raise error' do
        expect { validator.validate! }.not_to raise_error
      end
    end

    context 'when profile elements are present' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(200)
        allow(browser).to receive(:at_css).with('title').and_return(double(text: 'torvalds - GitHub'))
      end

      [ 'vcard-username', 'avatar-user', 'p-name', 'itemprop="name"' ].each do |marker|
        it "accepts page with #{marker} marker" do
          allow(browser).to receive(:body).and_return("<html><div>#{marker}</div></html>")
          expect { validator.validate! }.not_to raise_error
        end
      end
    end

    context 'when profile elements are missing' do
      before do
        allow(browser).to receive(:respond_to?).with(:status).and_return(true)
        allow(browser).to receive(:status).and_return(200)
        allow(browser).to receive(:at_css).with('title').and_return(double(text: 'Some Page'))
      end

      context 'and error pattern is found' do
        it 'raises ProfileNotFoundError for "this is not the web page you are looking for"' do
          allow(browser).to receive(:body).and_return('<html>This is not the web page you are looking for</html>')
          expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, "Perfil não encontrado")
        end

        it 'raises ProfileNotFoundError for "there isn\'t a github pages site here"' do
          allow(browser).to receive(:body).and_return('<html>There isn\'t a GitHub Pages site here.</html>')
          expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, "Perfil não encontrado")
        end

        it 'raises ProfileNotFoundError for "page not found"' do
          allow(browser).to receive(:body).and_return('<html>Page not found</html>')
          expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, "Perfil não encontrado")
        end

        it 'raises ProfileNotFoundError for "404 not found"' do
          allow(browser).to receive(:body).and_return('<html>404 - Not Found</html>')
          expect { validator.validate! }.to raise_error(Profiles::ProfileNotFoundError, "Perfil não encontrado")
        end
      end

      context 'and no error pattern is found' do
        it 'does not raise error' do
          allow(browser).to receive(:body).and_return('<html>Some other content</html>')
          expect { validator.validate! }.not_to raise_error
        end
      end
    end
  end
end
