# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::UnknownEnv, :config do
  let(:cop_config) do
    {
      'Environments' => %w[
        development
        production
        test
      ]
    }
  end

  # The following is a workaround which handles an upstream Ruby issue in which
  # the DidYouMean constants may not be available in versions of Ruby where
  # they are supposed to be available.
  if defined?(DidYouMean::SpellChecker)
    context 'when DidYouMean is available' do
      it 'registers an offense for typo of environment name' do
        expect_offense(<<~RUBY)
          Rails.env.proudction?
                    ^^^^^^^^^^^ Unknown environment `proudction`. Did you mean `production`?
          Rails.env.developpment?
                    ^^^^^^^^^^^^^ Unknown environment `developpment`. Did you mean `development`?
          Rails.env.something?
                    ^^^^^^^^^^ Unknown environment `something`.
          Rails.env.local?
                    ^^^^^^ Unknown environment `local`.
        RUBY
      end

      it 'registers an offense for typo of environment name with `==` operator' do
        expect_offense(<<~RUBY)
          Rails.env == 'proudction'
                       ^^^^^^^^^^^^ Unknown environment `proudction`. Did you mean `production`?
          'developpment' == Rails.env
          ^^^^^^^^^^^^^^ Unknown environment `developpment`. Did you mean `development`?

          'something' === Rails.env
          ^^^^^^^^^^^ Unknown environment `something`.

          'local' === Rails.env
          ^^^^^^^ Unknown environment `local`.
        RUBY
      end
    end
  else
    context 'when DidYouMean is not available' do
      it 'registers an offense for typo of environment name' do
        expect_offense(<<~RUBY)
          Rails.env.proudction?
                    ^^^^^^^^^^^ Unknown environment `proudction`.
          Rails.env.developpment?
                    ^^^^^^^^^^^^^ Unknown environment `developpment`.
          Rails.env.something?
                    ^^^^^^^^^^ Unknown environment `something`.

          Rails.env.local?
                    ^^^^^^ Unknown environment `local`.
        RUBY
      end

      it 'registers an offense for typo of environment name with `==` operator' do
        expect_offense(<<~RUBY)
          Rails.env == 'proudction'
                       ^^^^^^^^^^^^ Unknown environment `proudction`.
          'developpment' == Rails.env
          ^^^^^^^^^^^^^^ Unknown environment `developpment`.

          'something' === Rails.env
          ^^^^^^^^^^^ Unknown environment `something`.

          'local' === Rails.env
          ^^^^^^^ Unknown environment `local`.
        RUBY
      end
    end
  end

  it 'accepts correct environment name' do
    expect_no_offenses(<<~RUBY)
      Rails.env.production?
      Rails.env == 'production'
    RUBY
  end

  context 'Rails 7.1' do
    let(:config) do
      RuboCop::Config.new(
        {
          'AllCops' => {
            'TargetRailsVersion' => '7.1'
          },
          'Rails/UnknownEnv' => {
            'Environments' => %w[
              development
              production
              test
            ]
          }
        }
      )
    end

    it 'accepts local as an environment name on Rails 7.1' do
      expect_no_offenses(<<~RUBY)
        Rails.env.local?
        Rails.env == 'local'
      RUBY
    end
  end
end
