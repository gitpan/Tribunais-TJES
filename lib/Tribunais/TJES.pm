use strict;
use warnings;

package Tribunais::TJES;

use JSON;
use WWW::Mechanize;
use HTML::TreeBuilder::XPath;
use Path::Class;


sub new
{
    my $class = shift;
    my $self = {
	_edNumProcesso => shift,
	_seInstancia => shift,
	_sePesquisar => shift,
    };
    bless $self, $class;
    return $self;
}

sub sincroniza
{
    my($self) = @_;
    
    my $URI = "http://www.tj.es.gov.br/consulta/cfmx/portal/Novo/cons_proces.cfm";

    my $mech = WWW::Mechanize->new;
    $mech->agent_alias( 'Windows IE 6' );
    
    $mech->post($URI);
    
    my $html = $mech->content;
    
    $html =~ s[action="lista_proces.cfm"][action="desc_proces.cfm"]isg;
    $html =~ s[_blank][_self]isg;
    
    $mech->update_html( $html );


    $mech->submit_form(
	form_name => "cons_proces",
	fields      => {
	    seInstancia => $self->{_seInstancia},
	    sePesquisar => $self->{_sePesquisar},
	    edNumProcesso => $self->{_edNumProcesso},
	    seJuizo => "1",
	    seComarca => "0",
	    edNumCDA => "",
	    edAnoCDA => "",
	    edNumPetic => "",
	    edNumOriginPrim => "",
	    CdPessoa => "",
	    edNome => "",
	    SeqAdvog => "",
	    edNumOab => "",
	    edNomeAdv => "",
	    rbTipoNome => "1",
	    seSituacao => "1",
	    seNatureza => "1",
	    seTipoParte => "",
	}
    );
    
    my $titulo = $mech->title();
    $html = $mech->content;
    
    my $tree= HTML::TreeBuilder::XPath->new;
    $tree->parse( $html );
    
    my $table_rows = $tree->findnodes( '//div[@class=\'conteudo\']//table[1]//tr' );
    
    my $count = 0;
    my @items;
    
    foreach my $row ( $table_rows->get_nodelist )
    {
       if ( $count > 1 )
       { 
	    my $tree_tr = HTML::TreeBuilder::XPath->new;
	    $tree_tr->parse( $row->as_HTML );
	    my $strdata=$tree_tr->findvalue( '//span[1]' );
	    if(length($strdata)>5)
	    {
		my $row_data = {
		    data => $tree_tr->findvalue( '//span[1]' ),
		    andamento    => $tree_tr->findvalue( '//span[2]' ),
		    statusandamento   => $tree_tr->findvalue( '//span[3]' ),
		};
		push(@items, $row_data);
	    }
	    $tree_tr->delete;
       }
       $count++;
    }
    
    my $json = { fases => \@items }; # cria hash com nome de $json, insere no hash uma key com nome de andamentos tendo o array @registros no value dessa key
    
    my $string_json = to_json($json); # encoda o hash com nome de $json em uma string no formato JSON, e atribui à var $string_json
    
    return $string_json;
}

1;

__END__

=head1 NAME

Tribunais::TJES - Interface de consulta processual no Tribunal de Justiça do Espírito Santo - Brasil


=head1 SYNOPSIS

    use TJES;
    
    my $numerodoprocesso = "021070011867";

    my $tribunal = new Tribunais::TJES($numerodoprocesso, $seInstancia, $sePesquisar);

    print $tribunal->sincroniza;
    
=head1 AUTHORS

José Eduardo Perotta de Almeida, C<< eduardo at web2solutions.com.br >>


=head1 LICENSE AND COPYRIGHT

Copyright 2011 José Eduardo Perotta de Almeida.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
