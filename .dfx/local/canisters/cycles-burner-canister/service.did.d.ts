import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface config {
  'burn_rate' : bigint,
  'interval_between_timers_in_seconds' : bigint,
}
export interface _SERVICE { 'get_config' : ActorMethod<[], config> }
