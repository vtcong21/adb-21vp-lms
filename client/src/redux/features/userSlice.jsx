import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";
import ConvertRole from "~/hooks/ConvertRole";
import PublicService from "~/services/public";
export const GetUserInfo = createAsyncThunk(
  "user/getUserInfo",
  async ({ userId, password }, { rejectWithValue }) => {
    
    try {
      const res = await PublicService.login({
        userId: userId,
        password: password,
      });

      return res;
    } catch (err) {
      return rejectWithValue(err.response.data);
    }
  }
);

export const userSlice = createSlice({
  name: "user",
  initialState: {
    role: "public" || "AD" || "INS" || "LN",
    email: "",
    name: "",
    profilePhot: "",
    userId: "",
    gender: "",
    phone: "",
    DOB: "",
    address: "",
    degrees: "",
    workplace: "",
    scientitficBackground: "",
    vipState: "",
    loading: false,
    status: "idle",
    error: null,
  },
  reducers: {
    setRole: (state, action) => {
      state.role = action.payload;
    },
    deleteRole: (state) => {
      state.role = "public" || "AD" || "INS" || "LN";
      state.email = "";
      state.name = "";
      state.profilePhot = "";
      state.userId = "";
      state.gender = "";
      state.phone = "";
      state.DOB = "";
      state.address = "";
      state.degrees = "";
      state.workplace = "";
      state.scientitficBackground = "";
      state.vipState = "";
    },
    updateUserInfo: (state, action) => {
      state.role = action.payload.role;
      state.email = action.payload.email;
      state.name = action.payload.name;
      state.profilePhot = action.payload.profilePhot;
      state.userId = action.payload.userId;
      state.gender = action.payload.gender;
      state.phone = action.payload.phone;
      state.DOB = action.payload.DOB;
      state.address = action.payload.address;
      state.degrees = action.payload.degrees;
      state.workplace = action.payload.workplace;
      state.scientitficBackground = action.payload.scientitficBackground;
      state.vipState = action.payload.vipState;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(GetUserInfo.pending, (state) => {
        state.loading = true;
        state.status = "loading";
        state.error = null;
      })
      .addCase(GetUserInfo.fulfilled, (state, action) => {
        state.loading = false;
        state.status = "success";
        state.error = null;
      })
      .addCase(GetUserInfo.rejected, (state, action) => {
        state.loading = false;
        state.status = "failed";
        state.error = action.payload;
      });
  },
});
export const { setRole, deleteRole, updateUserInfo } = userSlice.actions;
export default userSlice.reducer;
