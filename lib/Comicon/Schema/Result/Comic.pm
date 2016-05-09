package Comicon::Schema::Result::Comic;
use Modern::Perl;
use utf8;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('comic');
__PACKAGE__->add_columns(
    'comic_id',
    {
        data_type => 'INTEGER',
        extra     => {
            unsigned => 1,
        },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    'filename',
    {
        data_type => 'VARCHAR',
        size      => 127,
    },
    'createtime',
    {
        data_type => 'DATETIME',
        time_zone => 'UTC',
    },
);

__PACKAGE__->set_primary_key('comic_id');
__PACKAGE__->has_many(
    frames => 'Comicon::Schema::Result::Frame',
    'comic_id',
);

1;
