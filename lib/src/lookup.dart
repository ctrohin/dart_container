enum LookupType {
  object,
  value,
}

class Lookup {
  final Type type;
  final String name;
  final LookupType lookupType;

  Lookup(this.type, this.lookupType, {this.name = ""});

  Lookup.object(Type type, {String name = ""})
      : this(type, LookupType.object, name: name);

  Lookup.value(String name) : this(Object, LookupType.value, name: name);
}
