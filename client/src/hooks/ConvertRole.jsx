const ConvertRole = (role) => {
  switch (role) {
    case "KH":
      return "guest";
    case "NV":
      return "staff";
    case "QTV":
      return "admin";
    case "NS":
      return "dentist";
    default:
      return "online";
  }
};

export default ConvertRole;
