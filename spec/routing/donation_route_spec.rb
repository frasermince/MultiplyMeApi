require 'rails_helper'

RSpec.describe "routing to donations", :type => :routing do

  it "does not expose a list of donations" do
    expect(:get => "/api/v1/donations").not_to be_routable
  end

  it "routes GET /api/v1/donations/:id to api/v1/donations#show" do
    expect(:get => "/api/v1/donations/1").to route_to(
    :controller => "api/v1/donations",
    :action => "show",
    :id => "1",
    :format => 'json'
    )
  end

  it "routes GET /api/v1/donations/:id.xml to api/v1/donations#show" do
    expect(:get => "/api/v1/donations/1.xml").to route_to(
    :controller => "api/v1/donations",
    :action => "show",
    :id => "1",
    :format => 'xml'
    )
  end

  it "routes POST /api/v1/donations to api/v1/donations#create" do
    expect(:post => "/api/v1/donations").to route_to(
    :controller => "api/v1/donations",
    :action => "create",
    :format => 'json'
    )
  end

  it "routes PUT /api/v1/donations/:id to api/v1/donations#update" do
    expect(:put => "/api/v1/donations/1").to route_to(
    :controller => "api/v1/donations",
    :action => "update",
    :id => '1',
    :format => 'json'
    )
  end

  it "does not delete list of donations" do
    expect(:delete => "/api/v1/donations").not_to be_routable
  end

  it "does not delete a specific donation" do
    expect(:delete => "/api/v1/donations/1").not_to be_routable
  end

end
