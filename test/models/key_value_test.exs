defmodule NelsonApproved.KeyValueTest do
  use NelsonApproved.ModelCase

  alias NelsonApproved.KeyValue

  @valid_attrs %{key: "some content", value: 42}
  @invalid_attrs %{}

  describe "changeset" do
    test "valid" do
      changeset = KeyValue.changeset(%KeyValue{}, @valid_attrs)
      assert changeset.valid?
    end

    test "invalid" do
      changeset1 = KeyValue.changeset(%KeyValue{}, @invalid_attrs)
      changeset2 = KeyValue.changeset(%KeyValue{}, %{key: "", value: 0})

      refute changeset1.valid?
      refute changeset2.valid?
    end
  end

  test "unique constraint on key" do
    # Given: Key already exist
    %KeyValue{}
    |> KeyValue.changeset(%{key: "existing", value: 10})
    |> Repo.insert!

    # Then: error when adding to repo
    changeset = KeyValue.changeset(%KeyValue{}, %{key: "existing", value: 3})
    assert {:error, changeset} = Repo.insert(changeset)
  end
end
