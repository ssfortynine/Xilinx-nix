{
  description = "Xilinx Flakes";
  
  outputs = { self }: {
    templates = import ./templates;
  };
}
