data "aws_route53_zone" "selected" {
  name         = "${var.route_53_name}"
}

resource "aws_route53_record" "Arecord" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.record_name}"
  type    = "A"

  alias {
    name                   = "${var.alias_record_name}"
    zone_id                = "${var.alias_zone_id}"
    evaluate_target_health = true
  }
}