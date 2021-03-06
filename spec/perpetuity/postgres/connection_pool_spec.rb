require 'perpetuity/postgres/connection_pool'

module Perpetuity
  class Postgres
    describe ConnectionPool do
      let(:pool) { ConnectionPool.new }

      it 'defaults to 5 connections' do
        pool.should have(5).connections
      end

      describe 'lending a connection' do
        it 'executes the given block' do
          expect { |probe| pool.lend_connection(&probe) }.to yield_control
        end

        it 'does not yield when there is no block given' do
          pool.lend_connection
        end

        it 'lends a connection for the duration of a block' do
          pool.lend_connection do |connection|
            pool.should have(4).connections
          end
          pool.should have(5).connections
        end

        it 'returns the value of the block' do
          pool.lend_connection { 1 }.should == 1
        end
      end

      it 'executes a given SQL statement' do
        sql = "SELECT TRUE"
        Connection.any_instance.should_receive(:execute)
                               .with(sql)
        pool.execute sql
      end

      it 'passes the tables message to a connection' do
        Connection.any_instance.should_receive(:tables)
        pool.tables
      end

      it 'cycles through each connection round-robin style' do
        connections = []
        pool.size.times do
          pool.lend_connection { |c| connections << c }
        end

        connections.uniq.should have(pool.size).items
      end
    end
  end
end
