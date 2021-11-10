test_that("rapidoc ui works", {
  skip("Manual test")
  pr <- pr()
  pr <- pr_set_docs(pr, "rapidoc")
  pr_run(pr, port = 8004, host = "0.0.0.0")
})
