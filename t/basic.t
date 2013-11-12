use Test::Most;
use Test::DZil;

# basing this on the [ModuleBuildDatabase] test for now

my $tzil = Builder->from_config(
  { dist_root => 'corpus/DZT' },
  { 
    add_files => { 
      'source/dist.ini' => simple_ini(
        {},
        'GatherDir',
        [ 'InsertFile' => {} ],
        [ 'InsertFile', 'FOO' => { file => '/insert_files/Foo.pod' } ],
      )
    }
  }
);

$tzil->build;

my($pm) = grep { $_->name eq 'lib/DZT.pm' } @{ $tzil->files };

like $pm->content, qr{^=head1 FOO$}m, "module contains inserted file using PluginName";
like $pm->content, qr{^=head1 BAR$}m, "module contains inserted file using path in template";

done_testing();

