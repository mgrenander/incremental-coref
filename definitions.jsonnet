// This could be autogenerated
local base = import "base.jsonnet";
local local_config = import "local.jsonnet";
{
  local log_root = local_config.log_root,

  // Main
  local Spb_on(segment) = (
    base.base +
    base.spanbert_base +
    base.Ontonotes(segment) +
    base.Name("spb_on_" + segment)
  ),

  // Eval exps
  local Eval(train_seg, test_seg) = Spb_on(train_seg) + base.Ontonotes(test_seg) + {
    preds_file: self.log_dir + "/" + "preds_" + test_seg + ".json"
  },

  // Experiments
  models: {
    ["spb_on_" + segment]: Spb_on(segment)
    for segment in [1, 5, 10, 128, 256, 384, 512]
  },

  evaluation: {
    ["spb_on_" + train + "_eval_" + test]: Eval(train, test)
    for train in [1, 5, 10, 128, 256, 384, 512]
    for test in [1, 10, 128, 512]
  },

  // Test
  test: {
     spb_on_512_dev: Spb_on(512) + {
      preds_file: self.log_dir + "/" + "dev.predictions.jsonlines",      
      evict_fn: {
        name: "trunc_linscale",
        distance: 600,
    	}
     },
 
    spb_on_512_test: Spb_on(512) + base.Ontonotes_Test(512) + {
      preds_file: self.log_dir + "/" + "test.predictions.jsonlines",      
      evict_fn: {
        name: "trunc_linscale",
        distance: 600,
    	}
     },
    spb_on_512_test_no_evict: Spb_on(512) + base.Ontonotes_Test(512) + {
      preds_file: self.log_dir + "/" + "test.predictions.jsonlines",      
      evict_fn: false,
     },
    spb_on_512_no_evict: Spb_on(512)  + {
      evict_fn: false,
    },
  }
}