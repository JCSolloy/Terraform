exports.handler = async (event) => {
    const groupMembers = [
      { lastName: "Doe", secondLastName: "Johnson" },
      { lastName: "Smith", secondLastName: "Brown" },
    ];
  
    return {
      statusCode: 200,
      body: JSON.stringify(groupMembers.map(member => `${member.lastName} ${member.secondLastName}`)),
    };
  };
  