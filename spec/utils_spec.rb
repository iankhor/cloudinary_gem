require 'spec_helper'
require 'cloudinary'

describe Cloudinary::Utils do
  before(:each) do
    Cloudinary.config do
      |config|
      config.cloud_name = "test123"
      config.secure_distribution = nil
      config.private_cdn = false
    end
  end
  
  it "should use cloud_name from config" do    
    result = Cloudinary::Utils.cloudinary_url("test")
    result.should == "http://res.cloudinary.com/test123/image/upload/test" 
  end

  it "should allow overriding cloud_name in options" do
    options = {:cloud_name=>"test321"}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test321/image/upload/test" 
  end
  
  it "should use default secure distribution if secure=true" do    
    options = {:secure=>true}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "https://d3jpl91pxevbkh.cloudfront.net/test123/image/upload/test" 
  end

  it "should allow overriding secure distribution if secure=true" do    
    options = {:secure=>true, :secure_distribution=>"something.else.com"}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "https://something.else.com/test123/image/upload/test" 
  end

  it "should take secure distribution from config if secure=true" do
    Cloudinary.config.secure_distribution = "config.secure.distribution.com"    
    options = {:secure=>true}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "https://config.secure.distribution.com/test123/image/upload/test" 
  end

  it "should raise exception if secure is given with private_cdn and no secure_distribution" do
    Cloudinary.config.private_cdn = true    
    lambda {Cloudinary::Utils.cloudinary_url("test", :secure=>true)}.should raise_error
  end

  it "should use format from options" do    
    options = {:format=>:jpg}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/test.jpg" 
  end

  it "should use width and height from options only if crop is given" do
    options = {:width=>100, :height=>100}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    result.should == "http://res.cloudinary.com/test123/image/upload/test" 
    options.should == {:width=>100, :height=>100}
    options = {:width=>100, :height=>100, :crop=>:crop}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {:width=>100, :height=>100}
    result.should == "http://res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test" 
  end
  
  it "should use x, y, radius, prefix, gravity and quality from options" do    
    options = {:x=>1, :y=>2, :radius=>3, :gravity=>:center, :quality=>0.4, :prefix=>"a"}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/g_center,p_a,q_0.4,r_3,x_1,y_2/test" 
  end
  
  it "should support named tranformation" do    
    options = {:transformation=>"blip"}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/t_blip/test" 
  end

  it "should support array of named tranformations" do    
    options = {:transformation=>["blip", "blop"]}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/t_blip.blop/test" 
  end

  it "should support base tranformation" do    
    options = {:transformation=>{:x=>100, :y=>100, :crop=>:fill}, :crop=>:crop, :width=>100}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {:width=>100}
    result.should == "http://res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/c_crop,w_100/test" 
  end

  it "should support array of base tranformations" do    
    options = {:transformation=>[{:x=>100, :y=>100, :width=>200, :crop=>:fill}, {:radius=>10}], :crop=>:crop, :width=>100}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {:width=>100}
    result.should == "http://res.cloudinary.com/test123/image/upload/c_fill,w_200,x_100,y_100/r_10/c_crop,w_100/test" 
  end

  it "should not include empty tranformations" do    
    options = {:transformation=>[{}, {:x=>100, :y=>100, :crop=>:fill}, {}]}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/test" 
  end

  it "should support size" do    
    options = {:size=>"10x10", :crop=>:crop}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {:width=>"10", :height=>"10"}
    result.should == "http://res.cloudinary.com/test123/image/upload/c_crop,h_10,w_10/test" 
  end

  it "should use type from options" do
    options = {:type=>:facebook}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/facebook/test" 
  end

  it "should use resource_type from options" do
    options = {:resource_type=>:raw}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/raw/upload/test" 
  end

  it "should ignore http links only if type is not given or is asset" do
    options = {:type=>nil}
    result = Cloudinary::Utils.cloudinary_url("http://test", options)
    options.should == {}
    result.should == "http://test" 
    options = {:type=>:asset}
    result = Cloudinary::Utils.cloudinary_url("http://test", options)
    options.should == {}
    result.should == "http://test" 
    options = {:type=>:fetch}
    result = Cloudinary::Utils.cloudinary_url("http://test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/fetch/http://test" 
  end

  it "should use allow absolute links to /images" do
    options = {}
    result = Cloudinary::Utils.cloudinary_url("/images/test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/test" 
  end 

  it "should use ignore absolute links not to /images" do
    options = {}
    result = Cloudinary::Utils.cloudinary_url("/js/test", options)
    options.should == {}
    result.should == "/js/test" 
  end 

  it "should escape fetch urls" do
    options = {:type=>:fetch}
    result = Cloudinary::Utils.cloudinary_url("http://blah.com/hello?a=b", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/fetch/http://blah.com/hello%3Fa%3Db" 
  end 

  it "should support background" do
    options = {:background=>"red"}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/b_red/test" 
    options = {:background=>"#112233"}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/b_rgb:112233/test" 
  end
  
  it "should support default_image" do
    options = {:default_image=>"default"}
    result = Cloudinary::Utils.cloudinary_url("test", options)
    options.should == {}
    result.should == "http://res.cloudinary.com/test123/image/upload/d_default/test" 
  end
  
end