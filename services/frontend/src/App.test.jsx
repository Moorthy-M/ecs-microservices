import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import App from "./App";

describe("App", () => {
  it("renders the main hero heading", () => {
    render(<App />);
    expect(
      screen.getByRole("heading", {
        level: 1,
        name: /operate fast, deploy safer, and scale with clarity\./i,
      }),
    ).toBeInTheDocument();
  });
});
