module RbVmomi

class VIM::HostSystem
  def esxcli
    if _connection.serviceContent.about.apiType != 'HostAgent'
      fail "esxcli is only supported when connecting directly to a host"
    end
    @esxcli ||= VIM::EsxcliNamespace.root(_connection)
  end
end

class VIM::EsxcliNamespace
  attr_reader :namespaces, :commands

  def self.root conn
    conn = conn
    ns = VIM::EsxcliNamespace.new nil, nil, nil
    dtm = VIM::InternalDynamicTypeManager(conn, 'ha-dynamic-type-manager')
    dti = dtm.DynamicTypeMgrQueryTypeInfo
    instances = dtm.DynamicTypeMgrQueryMoInstances
    path2obj = {}
    conn.class.loader.add_types dti.toRbvmomiTypeHash
    vmodl2info = Hash[dti.managedTypeInfo.map { |x| [x.name,x] }]
    instances.sort_by(&:moType).each do |inst|
      path = inst.moType.split('.')
      next unless path[0..1] == ['vim', 'EsxCLI']
      ns.add path[2..-1], conn, inst, vmodl2info[inst.moType]
    end
    ns
  end

  def initialize conn, inst, type
    @namespaces = {}
    @commands = {}
    @type = type
    if inst
      @obj = conn.type(type.wsdlName).new(conn, inst.id)
      type.method.each do |m|
        @commands[m.name] = m
      end
    else
      @obj = nil
    end
  end

  def add path, conn, inst, type
    child = path.shift
    if path.empty?
      fail if @namespaces.member? child
      @namespaces[child] = VIM::EsxcliNamespace.new conn, inst, type
    else
      @namespaces[child] ||= VIM::EsxcliNamespace.new nil, nil, nil
      @namespaces[child].add path, conn, inst, type
    end
  end

  def call name, args={}
    m = @commands[name]
    raise NoMethodError.new(name) unless m
    @obj._call m.wsdlName, args
  end

  def method_missing name, *args
    name = name.to_s
    if @namespaces.member? name and args.empty?
      @namespaces[name]
    elsif @commands.member? name
      call name, *args
    else
      raise NoMethodError
    end
  end

  def pretty_print q
    q.text "Namespaces: "
    @namespaces.keys.pretty_print q
    q.breakable
    q.text "Commands: "
    @commands.keys.pretty_print q
  end
end

end