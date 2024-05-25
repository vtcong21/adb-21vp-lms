import React from "react";

const PrintComponent = ({ componentToPrint }) => {
  return (
    <div>
      <h1>Print Preview</h1>
      {componentToPrint}
    </div>
  );
};

const ComponentToPrint = () => {
  return (
    <div>
      <h1>Hello World</h1>
      <p>This is a sample component.</p>
    </div>
  );
};

const PrintPage = () => {
  return (
    <div>
      <h1>Print Page</h1>
      <button onClick={() => window.print()}>Print</button>
    </div>
  );
};

const App = () => {
  return (
    <div>
      <PrintComponent componentToPrint={<ComponentToPrint />} />
      <PrintPage />
    </div>
  );
};

export default App;
