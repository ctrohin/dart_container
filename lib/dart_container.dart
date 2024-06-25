/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

export 'src/dart_container_base.dart'
    show
        injectorRegister,
        injectorGet,
        injectorGetIfPresent,
        injectorRegisterLazy,
        injectorRegisterFactory,
        injectorProvideValue,
        injectorProvideValues,
        injectorGetValue,
        injectorGetValueIfPresent,
        injectorSetProfile,
        injectorGetProfile;

export 'src/container.dart' show Container;
export 'src/container_builder.dart' show ContainerBuilder;
