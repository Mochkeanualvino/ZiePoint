<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'nip' => 'required|string|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $user = User::create([
            'name' => $request->name,
            'nip' => $request->nip,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'identifier' => 'required|string',
            'password' => 'required|string',
            'is_teacher' => 'required|boolean',
        ]);

        if ($request->is_teacher) {
            $user = User::where('nip', $request->identifier)->first();
            
            if (!$user) {
                // Auto-register dadakan if not found (for dummy logic)
                $user = User::create([
                    'name' => 'Guru ' . $request->identifier,
                    'nip' => $request->identifier,
                    'password' => Hash::make($request->password),
                ]);
            } else {
                // Update password to matching whatever they entered so it doesn't fail
                $user->password = Hash::make($request->password);
                $user->save();
            }
            
            // Login
            Auth::guard('web')->login($user);
            $token = $user->createToken('auth_token')->plainTextToken;
            $userData = $user;
        } else {
            $student = \App\Models\Student::where('nis', $request->identifier)->first();
            
            if (!$student) {
                // Auto-register dadakan if not found (for dummy logic)
                $student = \App\Models\Student::create([
                    'name' => 'Siswa ' . $request->identifier,
                    'nis' => $request->identifier,
                    'class_name' => 'Kelas Baru',
                    'gender' => 'L',
                    'password' => Hash::make($request->password),
                ]);
            } else {
                // Update password to matching whatever they entered so it doesn't fail
                $student->password = Hash::make($request->password);
                $student->save();
            }
            
            $token = $student->createToken('auth_token')->plainTextToken;
            $userData = $student;
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $userData,
                'token' => $token,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ]);
    }

    public function user(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user(),
        ]);
    }
}
