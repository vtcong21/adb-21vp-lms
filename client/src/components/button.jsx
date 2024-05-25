import React, { memo } from "react";

const ButtonGreen = memo(({ text, func, className }) => {
  return (
    <button
      className={`bg-grin font-montserrat font-bold text-md text-white py-2 
            px-5 rounded-xl mb-3 border-0 hover:bg-darkgrin active:bg-grin ${className}`}
      onClick={!func ? null : func}
    >
      {text}
    </button>
  );
});

const ButtonBorderGreen = memo(({ text, func, className }) => {
  return (
    <button
      className={`bg-white font-montserrat font-bold text-md text-grin py-2 
            px-4 rounded-xl border-grin mb-3 border-2 hover:bg-grin hover:text-white active:bg-white ${className}`}
      onClick={!func ? null : func}
    >
      {text}
    </button>
  );
});

const ButtonPink = memo(({ text, func, className }) => {
  return (
    <button
      className={`bg-pinkk font-montserrat font-bold text-md text-white py-2 
            px-5 rounded-xl mb-3 border-0 hover:bg-darkpinkk active:bg-pinkk  ${className}`}
      onClick={!func ? null : func}
    >
      {text}
    </button>
  );
});

const ButtonGrey = memo(({ text, func, className }) => {
  return (
    <button
      className={`bg-grey font-montserrat font-bold text-md text-white py-2 
            px-5 rounded-xl mb-3 border-0 hover:bg-darkgrey active:bg-grey ${className}`}
      onClick={!func ? null : func}
    >
      {text}
    </button>
  );
});
const ButtonBlue = memo(({ text, func, className }) => {
  return (
    <button
      className={`bg-blue font-montserrat font-bold text-md text-white py-2 
            px-5 rounded-xl mb-3 border-0 hover:bg-darkblue active:bg-blue ${className}`}
      onClick={!func ? null : func}
    >
      {text}
    </button>
  );
});
const Button = memo(
  ({ text, onClick, color, colorHover, colortext, className }) => {
    const textColor = colortext ? colortext : "black";
    return (
      <button
        className={`bg-${color} font-montserrat font-bold text-md text-${textColor} py-2 
            px-5 rounded-xl mb-3 border-0 hover:${colorHover} active:bg-red ${className}}`}
        onClick={!onClick ? null : onClick}
      >
        {text}
      </button>
    );
  }
);

export { ButtonGreen, ButtonPink, ButtonGrey, ButtonBlue, ButtonBorderGreen };

export default Button;
