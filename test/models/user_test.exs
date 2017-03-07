defmodule NelsonApproved.UserTest do
  use NelsonApproved.ModelCase
  alias NelsonApproved.User

  describe "Ensure valid data => " do
    test "fields cannot be empty" do
      assert {:username, "can't be blank"} in errors_on(%User{}, default_attrs(username: ""))
      assert {:password, "can't be blank"} in errors_on(%User{}, default_attrs(password: ""))
    end

    test "username must be 3 char minimum" do
      assert {:username, "should be at least 3 character(s)"} in errors_on(%User{}, default_attrs(username: "ab"))
    end
    test "username must be less than 20 char" do
      assert {:username, "should be at most 20 character(s)"} in errors_on(%User{}, default_attrs(username: "aaaaaaaaaaaaaaaaaaaaa"))
    end

    test "password must be 5 char minimum" do
      assert {:password, "should be at least 5 character(s)"} in errors_on(%User{}, default_attrs(password: "ab"))
    end
    test "password must be less than 20 char" do
      assert {:password, "should be at most 20 character(s)"} in errors_on(%User{}, default_attrs(password: "aaaaaaaaaaaaaaaaaaaaa"))
    end

    defp default_attrs(attr) do
      defaults = [username: "Username", password: "secret_pass", admin: false]
      Keyword.merge(defaults, attr) |> Enum.into(%{})
    end
  end

  test "admin defaults to false" do
    insert_user(username: "Hello", password: "password")

    from_repo = Repo.get_by(User, %{username: "Hello"})
    assert from_repo.admin == false
  end

  test "password is hashed and only hash is stored" do
    # Given: User in the database
    insert_user(username: "Hello", password: "password")

    # When: Getting the user
    from_repo = Repo.get_by(User, %{username: "Hello"})

    # Then: Password is hashed, and only hash is stored
    refute from_repo.password
    assert Comeonin.Bcrypt.checkpw("password", from_repo.pass_hash)
  end

  test "username is unique" do
    # Given: Username already exist
    insert_user(username: "Hello", password: "password")

    # When: Adding user with same username
    {:error, changeset} =
      %User{}
      |> User.changeset(%{username: "Hello", password: "secret"})
      |> Repo.insert()

    # Then: Error on changeset
    assert {:username, "has already been taken"} in format_errors(changeset)
  end

end
