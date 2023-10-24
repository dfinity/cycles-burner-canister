export const idlFactory = ({ IDL }) => {
  const config = IDL.Record({
    'burn_rate' : IDL.Nat,
    'interval_between_timers_in_seconds' : IDL.Nat64,
  });
  return IDL.Service({ 'get_config' : IDL.Func([], [config], ['query']) });
};
export const init = ({ IDL }) => { return []; };
