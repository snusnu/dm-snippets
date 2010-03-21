# -------------------- DIFFERENT KEY TYPES --------------------

# different key types are possible. if you have an author with an
# integer serial id, and you have an Article model whose FK id property
# is stored as a string, then this will work too.

# ---------------------- TRANSACTIONS --------------------------

it 'should rollback when an error is thrown in a transaction' do
  @user_model.all.should have(0).entries
  lambda {
    @user_model.transaction do
      @user_model.create(:name => 'carllerche')
      raise 'I love coffee'
    end
  }.should raise_error('I love coffee')
  @user_model.all.should have(0).entries
end

# --------------------------- STI ------------------------------

describe 'Model#new' do
  describe 'when provided a String discriminator in the attributes' do
    before :all do
      @resource = @article_model.new(:type => 'Blog::Release')
    end
    it 'should be an descendant instance' do
      @resource.should be_instance_of(Blog::Release)
    end
  end

  describe 'when provided a Class discriminator in the attributes' do
    before :all do
      @resource = @article_model.new(:type => Blog::Release)
    end
    it 'should be an descendant instance' do
      @resource.should be_instance_of(Blog::Release)
    end
  end

  describe 'when not provided a discriminator in the attributes' do
    before :all do
      @resource = @article_model.new
    end
    it 'should be a base model instance' do
      @resource.should be_instance_of(@article_model)
    end
  end
end

it 'should be retrieved as an instance of the correct class' do
  @announcement.model.get(*@announcement.key).should be_instance_of(@announcement_model)
end

it 'should include descendants in finders' do
  @article_model.first.should eql(@announcement)
end

it 'should not include ancestors' do
  @release_model.first.should be_nil
end

# ------------------------- MIGRATION ------------------------------

if @article_model.respond_to?(:auto_migrate!)
  @article_model.auto_migrate!(@alternate_adapter.name)
end

# ------------------------- BOOLEAN ------------------------------

describe 'when type primitive is a Boolean' do
  before do
    @property = Image.properties[:visible]
  end

  [ true, 'true', 'TRUE', '1', 1, 't', 'T' ].each do |value|
    it "returns true when value is #{value.inspect}" do
      @property.typecast(value).should be_true
    end
  end

  [ false, 'false', 'FALSE', '0', 0, 'f', 'F' ].each do |value|
    it "returns false when value is #{value.inspect}" do
      @property.typecast(value).should be_false
    end
  end

  [ 'string', 2, 1.0, BigDecimal('1.0'), DateTime.now, Time.now, Date.today, Class, Object.new, ].each do |value|
    it "does not typecast value #{value.inspect}" do
      @property.typecast(value).should equal(value)
    end
  end
end

# ------------------------- LAZY LOADING ------------------------------

describe 'lazy loading' do
  before :all do
    rescue_if 'TODO', @skip do
      @user.name    = 'dkubb'
      @user.age     = 33
      @user.summary = 'Programmer'

      # lazy load the description
      @user.description
    end
  end

  it 'should not overwrite dirty attribute' do
    @user.age.should == 33
  end

  it 'should not overwrite dirty lazy attribute' do
    @user.summary.should == 'Programmer'
  end

  it 'should not overwrite dirty key' do
    pending do
      @user.name.should == 'dkubb'
    end
  end
end

# ------------------------- RELATIONSHIPS ------------------------------

describe 'changing the parent resource' do
  before :all do
    @car = Car.create
    @engine = Engine.new
    @engine.car = @car
  end

  it 'should set the associated foreign key' do
    @engine.car_id.should == @car.id
  end

  it 'should add the engine object to the car' do
    pending 'Changing a belongs_to parent should add the object to the correct association' do
      @car.engines.should be_include(@engine)
    end
  end
end