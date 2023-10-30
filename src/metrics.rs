use crate::{get_counter, get_total_cycles_burnt, types::CandidHttpResponse};
use ic_metrics_encoder::MetricsEncoder;
use serde_bytes::ByteBuf;

/// Returns the metrics in the Prometheus format.
pub fn get_metrics() -> CandidHttpResponse {
    let now = ic_cdk::api::time();
    let mut writer = MetricsEncoder::new(vec![], (now / 1_000_000) as i64);
    match encode_metrics(&mut writer) {
        Ok(()) => {
            let body = writer.into_inner();
            CandidHttpResponse {
                status_code: 200,
                headers: vec![
                    (
                        "Content-Type".to_string(),
                        "text/plain; version=0.0.4".to_string(),
                    ),
                    ("Content-Length".to_string(), body.len().to_string()),
                ],
                body: ByteBuf::from(body),
            }
        }
        Err(err) => CandidHttpResponse {
            status_code: 500,
            headers: vec![],
            body: ByteBuf::from(format!("Failed to encode metrics: {}", err)),
        },
    }
}

/// Encodes the metrics in the Prometheus format.
fn encode_metrics(w: &mut MetricsEncoder<Vec<u8>>) -> std::io::Result<()> {
    let config = crate::storage::get_config();

    w.encode_gauge(
        "burn_amount",
        config.burn_amount as f64,
        "Current amout of cycles that are burnt in each operation.",
    )?;

    w.encode_gauge(
        "interval_between_timers_in_seconds",
        config.interval_between_timers_in_seconds as f64,
        "Current interval between burning operations.",
    )?;

    w.encode_gauge(
        "counter",
        get_counter() as f64,
        "Number of cycles burn operations executed.",
    )?;
    w.encode_gauge(
        "total_cycles_burnt",
        get_total_cycles_burnt() as f64,
        "Total number of cycles burnt using periodic prepayment.",
    )?;

    Ok(())
}
