exports.handler = async (event) => {
    const groupMembers = [
      { firstName: "John", secondName: "Doe" },
      { firstName: "Jane", secondName: "Smith" },
    ];
  
    return {
      statusCode: 200,
      body: JSON.stringify(groupMembers.map(member => `${member.firstName} ${member.secondName}`)),
    };
  };
  