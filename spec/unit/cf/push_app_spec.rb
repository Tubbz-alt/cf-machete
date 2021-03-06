# encoding: utf-8
require 'spec_helper'
require 'tmpdir'

module Machete
  module CF
    describe PushApp do
      let(:src_directory) { Dir.mktmpdir }
      let(:app) do
        double(:app, name: 'app_name',
                     src_directory: src_directory,
                     start_command: start_command,
                     stack: stack,
                     manifest: manifest,
                     buildpack: buildpack)
      end
      let(:start_command) { nil }
      let(:stack)         { nil }
      let(:buildpack)     { nil }
      let(:manifest)      { nil }

      subject(:push_app) { PushApp.new }

      before do
        allow(SystemHelper).to receive(:run_cmd)
        allow(app).to receive(:record_push_logs)
        allow(app).to receive(:start_logs)
        allow(app).to receive(:end_logs)
      end

      context 'default arguments' do
        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory}")
          push_app.execute(app)
        end
      end

      context 'start argument is false' do
        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory} --no-start")
          push_app.execute(app, start: false)
        end
      end

      context 'app has start command' do
        let(:start_command) { 'start_command' }

        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory} -c 'start_command'")
          push_app.execute(app)
        end
      end

      context 'app has a stack' do
        let(:stack) { 'stack' }

        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory} -s stack")
          push_app.execute(app)
        end
      end

      context 'app has a buildpack' do
        let(:buildpack) { 'my_buildpack' }

        specify do
          expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory} -b my_buildpack")
          push_app.execute(app)
        end
      end

      describe 'manifest.yml' do
        context 'app directory has a manifest.yml' do
          before do
            FileUtils.touch(File.join(src_directory, 'manifest.yml'))
          end

          after do
            FileUtils.rm_f(File.join(src_directory, 'manifest.yml'))
          end

          it 'uses that manifest' do
            expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory} -f #{src_directory}/manifest.yml")
            push_app.execute(app)
          end
        end

        context 'app is given a path to a manifest.yml' do
          let(:manifest) { 'path/to/manifest.yml' }

          it 'uses the passed manifest.yml' do
            expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory} -f path/to/manifest.yml")
            push_app.execute(app)
          end
        end

        context 'app is given a path to a manifest.yml and one exists in the app directory' do
          let(:manifest) { 'path/to/manifest.yml' }

          before do
            FileUtils.touch(File.join(src_directory, 'manifest.yml'))
          end

          after do
            FileUtils.rm_f(File.join(src_directory, 'manifest.yml'))
          end

          it 'uses the passed manifest.yml' do
            expect(SystemHelper).to receive(:run_cmd).with("cf push --random-route app_name -p #{src_directory} -f path/to/manifest.yml")
            push_app.execute(app)
          end
        end
      end
    end
  end
end
