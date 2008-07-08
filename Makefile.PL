use inc::Module::Install;
name     'Lorzy';
all_from 'lib/Lorzy.pm';

requires perl => '5.008';
requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::ClassAttribute';

requires 'Module::Pluggable';
requires 'Params::Validate';

build_requires 'Test::More';
build_requires 'Test::Exception';

WriteAll;

