package AWS::SNS::Confess;
use base 'Exporter';
use Amazon::SNS;
use Devel::StackTrace;
use strict;
use warnings 'all';

our @EXPORT_OK = qw/confess/;

our ($access_key_id, $secret_access_key, $topic, $sns, $sns_topic);

sub setup
{
  my (%args) = @_;
  $access_key_id = $args{access_key_id};
  $secret_access_key = $args{secret_access_key};
  $topic = $args{topic};
  $sns = $args{sns} || Amazon::SNS->new(
    key => $access_key_id,
    secret => $secret_access_key,
  );
  $sns->service(_service_url());
  $sns_topic = $sns->GetTopic($topic);
}

sub confess
{
  my ($msg) = @_;
  my $full_message = "Runtime Error: $msg\n"
    . Devel::StackTrace->new->as_string;

  _send_msg( $full_message );
  die $msg;
}

sub _service_url
{
  die "no topic specified" unless $topic;
  if ($topic =~ m/^arn:aws:sns:([^:]+):\d+:[^:]+$/)
  {
    return "http://sns.$1.amazonaws.com";
  }
  return "http://sns.us-east-1.amazonaws.com";
}

sub _send_msg
{
  $sns_topic->Publish(shift);
}

1;
