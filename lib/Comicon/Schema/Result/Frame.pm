package Comicon::Schema::Result::Frame;
use Modern::Perl;
use utf8;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('frame');
__PACKAGE__->add_columns(
    'frame_id',
    {
        data_type => 'INTEGER',
        extra     => {
            unsigned => 1,
        },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    'comic_id',
    {
        data_type => 'INTEGER',
        extra     => {
            unsigned => 1,
        },
        is_nullable => 0,
    },
    'text',
    {
        data_type   => 'VARCHAR',
        size        => 256,
        is_nullable => 0,
    },
    'coordinates',
    {
        data_type   => 'VARCHAR',
        size        => 32,
        is_nullable => 0,
    }
);

__PACKAGE__->set_primary_key('frame_id');
__PACKAGE__->belongs_to(
    comic => 'Comicon::Schema::Result::Comic',
    'comic_id',
);

1;
